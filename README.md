# ninja_ripper


4698to 于 2017-7-13 20:55 编辑


ninjaripper 这个神器 就不多说了，可以在游戏中直接抓取模型出来。然后配合插件脚本把模型导入到max /blender 里面。用过的人都知道，导入是时候很麻烦啊，要一片片的找的，很多都是UV错的，要慢慢找到那些UV对的才行，找到对的之后又要慢慢找坏的删除。。。。

![image](https://github.com/4698to/ninja_ripper/blob/master/214007g98w8mmhc9m6w6r6.jpg)
![image](https://github.com/4698to/ninja_ripper/blob/master/214441dqiiaouzq496ovnn.jpg)

*1:NO UV  ：
    在UV coord参数设置正确的情况下导入过程中检查模型UV是否正常，不正常的UV一般都是所以uv点都挤成00/01，如果你发现模型UV是某个侧视图横截面，或是一条线，基本上都是UV coord参数 设置错误。导入完成之后，点下 1:NO UV 就可以把所以UV错误的模型删除。

*2:Same Size :
    检查是否有重合模型，选中一个 点2:same size 就可以自动把重复的模型删除。谨慎使用， same size不会检查模型是否有问题，只是单纯的删除重复的只保留一个。

*3:Map Path :
    收集贴图
    自动把在ninjaripper 提取出来的贴图中正确的从rip模型目录复制到当前操作的MAX保存目录下。

正常使用流程：
    选用Group d导入模式，INput Dir 填上导入路径，RIP File Nums 填序列，如： 0-50  ，即导入 前50个RIP模型文件。
    UV Coord 一般都是 U3 V4 ，你可以慢慢测试这个参数。
    导入成功后，点 1:NO UV 删除。
    然后继续。。。
完成后，保存为 max 文件，点3:Map Path  自动把贴图收集到你max文件同目录下。
